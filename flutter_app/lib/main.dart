import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/api_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/main_screen.dart';
import 'screens/posting/create_post_screen.dart';
import 'screens/post/post_details_screen.dart';
import 'screens/profile/my_posts_screen.dart';
import 'screens/chat/chat_list_screen.dart';
import 'screens/chat/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await StorageService().init();
  ApiService().init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Classifieds Marketplace',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            home: _buildHomeScreen(authProvider),
            onGenerateRoute: (settings) {
              // Handle routes with arguments
              if (settings.name == '/post-details') {
                final postId = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (context) => PostDetailsScreen(postId: postId),
                );
              }
              
              if (settings.name == '/chat') {
                final args = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    conversationId: args['conversationId'],
                    otherUserName: args['otherUserName'],
                  ),
                );
              }
              
              return null;
            },
            routes: {
              '/welcome': (context) => const WelcomeScreen(),
              '/signup': (context) => const SignupScreen(),
              '/login': (context) => const LoginScreen(),
              '/email-verification': (context) => const EmailVerificationScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/reset-password': (context) => const ResetPasswordScreen(),
              '/main': (context) => const MainScreen(),
              '/create-post': (context) => const CreatePostScreen(),
              '/my-posts': (context) => const MyPostsScreen(),
              '/chat-list': (context) => const ChatListScreen(),
            },
          );
        },
      ),
    );
  }

  Widget _buildHomeScreen(AuthProvider authProvider) {
    // Show loading while checking auth state
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Navigate based on auth state
    if (authProvider.isAuthenticated && authProvider.user != null) {
      // Use user ID as key to force recreation when switching users
      return _AuthenticatedApp(key: ValueKey(authProvider.user!.id));
    }

    return const WelcomeScreen();
  }
}

// Wrapper to initialize chat for authenticated users
class _AuthenticatedApp extends StatefulWidget {
  const _AuthenticatedApp({Key? key}) : super(key: key);

  @override
  State<_AuthenticatedApp> createState() => _AuthenticatedAppState();
}

class _AuthenticatedAppState extends State<_AuthenticatedApp> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    
    // Get current user ID for logging
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _currentUserId = authProvider.user?.id;
    
    print('🆕 _AuthenticatedApp initState() called for user: ${authProvider.user?.name} (ID: ${_currentUserId})');
    
    // Initialize chat connection for this user session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      try {
        final chatProvider = context.read<ChatProvider>();
        print('🔄 Reinitializing ChatProvider for new user session...');
        chatProvider.initialize();
      } catch (e) {
        print('❌ Error accessing ChatProvider in postFrameCallback: $e');
      }
    });
  }

  @override
  void dispose() {
    print('🗑️ _AuthenticatedApp dispose() called for user: $_currentUserId');
    
    try {
      // Disconnect chat when user logs out
      final chatProvider = context.read<ChatProvider>();
      print('🗑️ Disposing chat for user logout...');
      chatProvider.disposeChat();
    } catch (e) {
      print('⚠️ Error disposing ChatProvider: $e');
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}


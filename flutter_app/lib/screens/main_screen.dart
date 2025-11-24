import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import 'home/home_feed_screen.dart';
import 'profile/profile_screen.dart';
import 'chat/chat_list_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeFeedScreen(),
    const ChatListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Check if there are routes that can be popped
        final navigator = Navigator.of(context);
        final canPopRoute = navigator.canPop();
        
        return PopScope(
          // Prevent back navigation when authenticated and at root
          // This prevents going back to signup/login screens
          canPop: !authProvider.isAuthenticated || canPopRoute,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            
            // If user is authenticated and can't pop (at root), prevent navigation
            if (authProvider.isAuthenticated && !canPopRoute) {
              // User is at root of authenticated app, prevent back navigation
              return;
            }
          },
          child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      bottomNavigationBar: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textLight,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            elevation: 8,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  label: Text('${chatProvider.unreadCount}'),
                  isLabelVisible: chatProvider.unreadCount > 0,
                  child: const Icon(Icons.chat_bubble_outline),
                ),
                activeIcon: Badge(
                  label: Text('${chatProvider.unreadCount}'),
                  isLabelVisible: chatProvider.unreadCount > 0,
                  child: const Icon(Icons.chat_bubble),
                ),
                label: 'Chats',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
      ),
        );
      },
    );
  }
}

import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  useReactTable,
  getCoreRowModel,
  getFilteredRowModel,
  getPaginationRowModel,
  flexRender,
} from '@tanstack/react-table';
import axiosInstance from '../lib/axios';
import { Button } from '../components/ui/button';
import { Input } from '../components/ui/input';
import { Badge } from '../components/ui/badge';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../components/ui/card';
import { Tabs, TabsList, TabsTrigger } from '../components/ui/tabs';
import { motion } from 'framer-motion';
import {
  CheckCircle,
  XCircle,
  Search,
  ChevronLeft,
  ChevronRight,
  MapPin,
  DollarSign,
  Tag,
} from 'lucide-react';

export default function AdsReview() {
  const [globalFilter, setGlobalFilter] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [statusFilter, setStatusFilter] = useState('pending');
  const queryClient = useQueryClient();

  // Fetch posts with status filter
  const { data, isLoading } = useQuery({
    queryKey: ['posts', statusFilter, currentPage, globalFilter],
    queryFn: async () => {
      const response = await axiosInstance.get('/admin/posts', {
        params: {
          page: currentPage,
          limit: 10,
          search: globalFilter,
          status: statusFilter,
        },
      });
      return response.data.data;
    },
  });

  // Approve mutation
  const approveMutation = useMutation({
    mutationFn: (postId) => axiosInstance.patch(`/admin/posts/${postId}/approve`),
    onSuccess: () => {
      queryClient.invalidateQueries(['posts']);
      queryClient.invalidateQueries(['overview']);
    },
  });

  // Reject mutation
  const rejectMutation = useMutation({
    mutationFn: (postId) => axiosInstance.patch(`/admin/posts/${postId}/reject`),
    onSuccess: () => {
      queryClient.invalidateQueries(['posts']);
      queryClient.invalidateQueries(['overview']);
    },
  });

  const columns = [
    {
      accessorKey: 'images',
      header: 'Image',
      cell: ({ row }) => {
        const images = row.getValue('images');
        const firstImage = Array.isArray(images) && images.length > 0 ? images[0] : null;
        const apiUrl = import.meta.env.VITE_API_URL 
          ? import.meta.env.VITE_API_URL.replace('/api', '')
          : 'http://localhost:5000';
        
        return (
          <div className="w-16 h-16 rounded-lg overflow-hidden bg-muted">
            {firstImage ? (
              <img
                src={`${apiUrl}${firstImage}`}
                alt={row.original.title}
                className="w-full h-full object-cover"
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center">
                <Tag className="w-6 h-6 text-muted-foreground" />
              </div>
            )}
          </div>
        );
      },
    },
    {
      accessorKey: 'title',
      header: 'Title',
      cell: ({ row }) => (
        <div className="max-w-xs">
          <p className="font-medium truncate">{row.getValue('title')}</p>
          <p className="text-sm text-muted-foreground truncate">
            {row.original.description || 'No description'}
          </p>
        </div>
      ),
    },
    {
      accessorKey: 'category',
      header: 'Category',
      cell: ({ row }) => (
        <Badge variant="secondary" className="capitalize">
          {row.getValue('category')}
        </Badge>
      ),
    },
    {
      accessorKey: 'price',
      header: 'Price',
      cell: ({ row }) => (
        <div className="flex items-center space-x-1">
          <DollarSign className="w-4 h-4 text-muted-foreground" />
          <span className="font-semibold">{row.getValue('price').toLocaleString()}</span>
        </div>
      ),
    },
    {
      accessorKey: 'location',
      header: 'Location',
      cell: ({ row }) => {
        const location = row.getValue('location');
        return (
          <div className="flex items-center space-x-1 text-sm text-muted-foreground max-w-xs">
            <MapPin className="w-4 h-4 flex-shrink-0" />
            <span className="truncate">{location?.address || 'No address'}</span>
          </div>
        );
      },
    },
    {
      accessorKey: 'createdBy',
      header: 'Posted By',
      cell: ({ row }) => {
        const user = row.getValue('createdBy');
        return (
          <div className="text-sm">
            <p className="font-medium">{user?.name || 'Unknown'}</p>
            <p className="text-muted-foreground text-xs">{user?.email || ''}</p>
          </div>
        );
      },
    },
    {
      accessorKey: 'status',
      header: 'Status',
      cell: ({ row }) => {
        const status = row.getValue('status');
        return (
          <Badge
            variant={getBadgeVariant(status)}
            className={`capitalize ${
              status === 'pending'
                ? 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300'
                : status === 'approved'
                ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300'
                : status === 'rejected'
                ? 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'
                : ''
            }`}
          >
            {status}
          </Badge>
        );
      },
    },
    {
      id: 'actions',
      header: 'Actions',
      cell: ({ row }) => {
        const status = row.original.status;
        
        // Only show action buttons for pending posts
        if (status !== 'pending') {
          return (
            <span className="text-sm text-muted-foreground">
              {status === 'approved' && '✓ Approved'}
              {status === 'rejected' && '✗ Rejected'}
            </span>
          );
        }
        
        return (
          <div className="flex items-center space-x-2">
            <Button
              size="sm"
              variant="default"
              onClick={() => approveMutation.mutate(row.original._id)}
              disabled={approveMutation.isPending || rejectMutation.isPending}
              className="bg-green-600 hover:bg-green-700"
            >
              <CheckCircle className="w-4 h-4 mr-1" />
              Approve
            </Button>
            <Button
              size="sm"
              variant="destructive"
              onClick={() => rejectMutation.mutate(row.original._id)}
              disabled={approveMutation.isPending || rejectMutation.isPending}
            >
              <XCircle className="w-4 h-4 mr-1" />
              Reject
            </Button>
          </div>
        );
      },
    },
  ];

  const table = useReactTable({
    data: data?.posts || [],
    columns,
    getCoreRowModel: getCoreRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    state: {
      globalFilter,
    },
    onGlobalFilterChange: setGlobalFilter,
  });

  if (isLoading) {
    return (
      <div className="space-y-6">
        <Card>
          <CardHeader>
            <div className="h-8 bg-muted rounded w-48 animate-pulse"></div>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {[...Array(5)].map((_, i) => (
                <div key={i} className="h-16 bg-muted rounded animate-pulse"></div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    );
  }

  // Status filter options
  const statusOptions = [
    { value: 'all', label: 'All', color: 'default' },
    { value: 'pending', label: 'Pending', color: 'yellow' },
    { value: 'approved', label: 'Approved', color: 'green' },
    { value: 'rejected', label: 'Rejected', color: 'red' },
  ];

  // Get badge variant based on status
  const getBadgeVariant = (status) => {
    switch (status) {
      case 'approved':
        return 'default';
      case 'rejected':
        return 'destructive';
      default:
        return 'secondary';
    }
  };

  // Reset page when filter changes
  const handleFilterChange = (newStatus) => {
    setStatusFilter(newStatus);
    setCurrentPage(1);
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h2 className="text-3xl font-bold tracking-tight">Advertisements Review</h2>
        <p className="text-muted-foreground">Review and moderate all advertisements</p>
      </div>

      {/* Filter Tabs */}
      <Card>
        <CardContent className="pt-6">
          <Tabs value={statusFilter} className="w-full">
            <TabsList className="grid w-full grid-cols-4 lg:w-auto">
              {statusOptions.map((option) => (
                <TabsTrigger
                  key={option.value}
                  value={option.value}
                  active={statusFilter === option.value}
                  onClick={() => handleFilterChange(option.value)}
                  className="relative"
                >
                  {option.label}
                  {data?.statusCounts?.[option.value] !== undefined && (
                    <Badge
                      variant="secondary"
                      className={`ml-2 ${
                        option.color === 'yellow'
                          ? 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-300'
                          : option.color === 'green'
                          ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-300'
                          : option.color === 'red'
                          ? 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-300'
                          : ''
                      }`}
                    >
                      {data.statusCounts[option.value]}
                    </Badge>
                  )}
                </TabsTrigger>
              ))}
            </TabsList>
          </Tabs>
        </CardContent>
      </Card>

      {/* Stats */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardContent className="pt-6">
            <div className="text-2xl font-bold">{data?.total || 0}</div>
            <p className="text-xs text-muted-foreground">
              {statusFilter === 'all' ? 'Total Ads' : `Total ${statusFilter.charAt(0).toUpperCase() + statusFilter.slice(1)}`}
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="text-2xl font-bold text-green-600">
              {approveMutation.isSuccess ? '✓' : '—'}
            </div>
            <p className="text-xs text-muted-foreground">Recently Approved</p>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="text-2xl font-bold text-red-600">
              {rejectMutation.isSuccess ? '✓' : '—'}
            </div>
            <p className="text-xs text-muted-foreground">Recently Rejected</p>
          </CardContent>
        </Card>
      </div>

      {/* Table */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>Advertisements</CardTitle>
              <CardDescription>Review and moderate pending ads</CardDescription>
            </div>
            <div className="relative w-full max-w-sm">
              <Search className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search by title or category..."
                value={globalFilter ?? ''}
                onChange={(e) => setGlobalFilter(e.target.value)}
                className="pl-10"
              />
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {data?.posts?.length === 0 ? (
            <div className="text-center py-12">
              <CheckCircle className="w-16 h-16 mx-auto text-green-600 mb-4" />
              <h3 className="text-xl font-semibold mb-2">
                {statusFilter === 'pending' && 'All caught up!'}
                {statusFilter === 'approved' && 'No approved ads yet'}
                {statusFilter === 'rejected' && 'No rejected ads'}
                {statusFilter === 'all' && 'No ads found'}
              </h3>
              <p className="text-muted-foreground">
                {statusFilter === 'pending' && 'There are no pending ads to review.'}
                {statusFilter === 'approved' && 'Approved ads will appear here.'}
                {statusFilter === 'rejected' && 'Rejected ads will appear here.'}
                {statusFilter === 'all' && 'No advertisements have been posted yet.'}
              </p>
            </div>
          ) : (
            <>
              {/* Table */}
              <div className="rounded-md border overflow-x-auto">
                <table className="w-full">
                  <thead>
                    {table.getHeaderGroups().map((headerGroup) => (
                      <tr key={headerGroup.id} className="border-b bg-muted/50">
                        {headerGroup.headers.map((header) => (
                          <th
                            key={header.id}
                            className="px-4 py-3 text-left text-sm font-medium"
                          >
                            {header.isPlaceholder
                              ? null
                              : flexRender(header.column.columnDef.header, header.getContext())}
                          </th>
                        ))}
                      </tr>
                    ))}
                  </thead>
                  <tbody>
                    {table.getRowModel().rows.map((row, index) => (
                      <motion.tr
                        key={row.id}
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: index * 0.05 }}
                        className="border-b hover:bg-muted/50 transition-colors"
                      >
                        {row.getVisibleCells().map((cell) => (
                          <td key={cell.id} className="px-4 py-4">
                            {flexRender(cell.column.columnDef.cell, cell.getContext())}
                          </td>
                        ))}
                      </motion.tr>
                    ))}
                  </tbody>
                </table>
              </div>

              {/* Pagination */}
              <div className="flex items-center justify-between mt-4">
                <p className="text-sm text-muted-foreground">
                  Showing page {data?.currentPage || 1} of {data?.totalPages || 1}
                </p>
                <div className="flex items-center space-x-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                    disabled={currentPage === 1}
                  >
                    <ChevronLeft className="w-4 h-4 mr-1" />
                    Previous
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => setCurrentPage((p) => p + 1)}
                    disabled={currentPage >= (data?.totalPages || 1)}
                  >
                    Next
                    <ChevronRight className="w-4 h-4 ml-1" />
                  </Button>
                </div>
              </div>
            </>
          )}
        </CardContent>
      </Card>
    </div>
  );
}


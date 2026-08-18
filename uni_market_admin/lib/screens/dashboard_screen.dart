import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/navigation_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboardStats();
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF1E3A5F),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Text(
          'Error: ${provider.errorMessage}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final stats = provider.stats;
    if (stats == null) {
      return const Center(child: Text('No statistical data fetched.'));
    }

    final size = MediaQuery.of(context).size;
    final crossAxisCount = size.width > 1200
        ? 4
        : size.width > 800
            ? 3
            : size.width > 600
                ? 2
                : 1;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row for Quick statistics
          GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStatCard(
                title: 'Total Users',
                value: '${stats.totalUsers}',
                icon: Icons.people,
                color: Colors.blue,
                onTap: () => context.read<NavigationProvider>().setSelectedIndex(1),
              ),
              _buildStatCard(
                title: 'Total Products',
                value: '${stats.totalProducts}',
                icon: Icons.storefront,
                color: Colors.indigo,
                onTap: () => context.read<NavigationProvider>().setSelectedIndex(2),
              ),
              _buildStatCard(
                title: 'Total Orders',
                value: '${stats.totalOrders}',
                icon: Icons.shopping_cart,
                color: Colors.green,
                onTap: () => context.read<NavigationProvider>().setSelectedIndex(3),
              ),
              _buildStatCard(
                title: 'Total Revenue',
                value: '৳${stats.totalRevenue.toStringAsFixed(2)}',
                icon: Icons.monetization_on,
                color: const Color(0xFFD4A017),
                onTap: () => context.read<NavigationProvider>().setSelectedIndex(3),
              ),
              _buildStatCard(
                title: 'Rent Requests',
                value: '${stats.totalRentRequests}',
                icon: Icons.key,
                color: Colors.teal,
                onTap: () => context.read<NavigationProvider>().setSelectedIndex(4),
              ),
              _buildStatCard(
                title: 'Exchange Requests',
                value: '${stats.totalExchangeRequests}',
                icon: Icons.swap_horiz,
                color: Colors.deepOrange,
                onTap: () => context.read<NavigationProvider>().setSelectedIndex(5),
              ),
            ],
          ),

        ],
      ),
    );
  }
}

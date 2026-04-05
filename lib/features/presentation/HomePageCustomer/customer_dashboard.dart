import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

import 'BillingHistory/billing_history.dart';
import 'Usage/usage.dart';
import 'Announcements/announcement.dart';
import 'ReportIssue/report_issue.dart';

import '../../providers/LoginProvider/auth_provider.dart';
import '../../providers/CustomerProviders/billing_history&usage_provider.dart';
import '../../providers/CustomerProviders/billing_usage_page_provider.dart';

import '../LoginPage/login_page.dart';
import 'Chatbot/chatbot_fab.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _fetchBillingData();
  }

  void _fetchBillingData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final billingBreakdownProvider = Provider.of<BillBreakdownProvider>(
      context,
      listen: false,
    );
    final billingProvider = Provider.of<BillingProvider>(
      context,
      listen: false,
    );

    // Fetch billing breakdown for current user
    billingBreakdownProvider.fetchBillBreakdown(
      authProvider.accountNumber.toString(),
    );

    // Fetch last month usage info if not fetched
    if (billingProvider.currentAmountDue == 0) {
      billingProvider.fetchBillingInfo(authProvider.accountNumber.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'gripometer',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: false,
      ),
    floatingActionButton: Column(
  mainAxisSize: MainAxisSize.min,
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [
    // Report Issue on top
    FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportIssuePage()),
        );
      },
      icon: const Icon(Icons.report_problem, color: Colors.white),
      label: const Text(
        'Report an Issue',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: colors.primary,
    ),
    const SizedBox(height: 12),

    // Chatbot below
    FloatingActionButton.extended(
      onPressed: () => showChatbotSheet(context),
      icon: const Icon(Icons.chat_bubble, color: Colors.white),
      label: const Text(
        'Chat Assistant',
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: colors.primary, // choose a distinct color
    ),
  ],
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileCard(context, authProvider, colors),
            const SizedBox(height: 12),

            // =========================
            // Current Amount Due Card (Consumer rebuilds on provider change)
            // =========================
            Consumer<BillBreakdownProvider>(
              builder: (context, billingBreakdownProvider, child) {
                return _buildAmountDueCard(context, billingBreakdownProvider);
              },
            ),

            const SizedBox(height: 12),

            // =========================
            // Action Cards
            // =========================
            _buildActionCards(context),

            const SizedBox(height: 12),

            // =========================
            // Announcements
            // =========================
            Card(
              color: colors.surfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: ListTile(
                title: const Text(
                  'News and Announcements',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AnnouncementPage()),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // =========================
            // Carousel Slider
            // =========================
            CarouselSlider(
              options: CarouselOptions(
                height: 160,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.8,
              ),
              items:
                  [
                    'assets/images/announcement1.jpg',
                    'assets/images/announcement2.jpg',
                    'assets/images/announcement3.jpg',
                  ].map((path) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        path,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  

  Widget _buildProfileCard(
    BuildContext context,
    AuthProvider authProvider,
    ColorScheme colors,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: colors.primary,
              child: Text(
                '${(authProvider.firstName ?? '').isNotEmpty ? authProvider.firstName![0] : ''}'
                '${(authProvider.lastName ?? '').isNotEmpty ? authProvider.lastName![0] : ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${authProvider.firstName} ${authProvider.lastName}',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Account #: ${authProvider.accountNumber}',
                    style: Theme.of(
                      context,
                    ).textTheme.titleSmall?.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.wifi, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Online',
                        style: TextStyle(fontSize: 12, color: colors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: Colors.red),
              tooltip: 'Logout',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final billingProvider = Provider.of<BillingProvider>(context);
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            title: 'Billing History',
            subtitle: 'Last 18 months',
            icon: LucideIcons.clock,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BillingHistoryPage()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context,
            title: 'Usage',
            subtitle:
                'Last Month',
            icon: LucideIcons.droplets,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BillBreakdownPage()),
            ),
          ),
        ),
      ],
    );
  }

  // =========================
  // Amount Due Card + Modal Sheet
  // =========================
  Widget _buildAmountDueCard(
    BuildContext context,
    BillBreakdownProvider billingBreakdownProvider,
  ) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // Modal sheet
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 60,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Summary of your current charges, past payments, and overall account balance.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildBillingModalContent(
                        context,
                        billingBreakdownProvider,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      child: Card(
        color: colors.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Amount Due',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '₱${billingBreakdownProvider.currentAmountDue.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Icon(LucideIcons.coins, size: 40, color: colors.primary),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Due: ${DateFormat('MMMM d, y').format(billingBreakdownProvider.dueDate)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillingModalContent(
    BuildContext context,
    BillBreakdownProvider billingBreakdownProvider,
  ) {
    return Column(
      children: [
        // Usage details
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Previous Reading',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${billingBreakdownProvider.previousReading} m³',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'MMM d, y',
                    ).format(billingBreakdownProvider.previousReadingDate),
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.timeline, color: Colors.blueGrey),
                  Text(
                    '${billingBreakdownProvider.readingIntervalDays} days',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Current Reading',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${billingBreakdownProvider.currentReading} m³',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat(
                      'MMM d, y',
                    ).format(billingBreakdownProvider.currentReadingDate),
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 36),
        _billingRow(
          'Total Usage',
          '${billingBreakdownProvider.totalUsage} m³',
          valueStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const Divider(height: 36),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Billing Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _billingRow(
          'Latest Consumption',
          '₱${billingBreakdownProvider.waterConsumption.toStringAsFixed(2)}',
        ),
        _billingRow(
          'Maintenance Fee',
          '₱${billingBreakdownProvider.maintenanceFee.toStringAsFixed(2)}',
        ),
        _billingRow(
          'Taxes',
          '₱${billingBreakdownProvider.taxes.toStringAsFixed(2)}',
        ),
        _billingRow(
          'Unpaid Bill',
          '₱${billingBreakdownProvider.unpaidBill.toStringAsFixed(2)}',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BillingHistoryPage()),
            );
          },
        ),
        const Divider(height: 36),
        _billingRow(
          'Total Payment',
          '₱${billingBreakdownProvider.totalPayment.toStringAsFixed(2)}',
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          valueStyle: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const Divider(height: 36),
        const Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Please ensure that your bill is paid before the due date. For assistance, contact our customer service.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _billingRow(
    String label,
    String value, {
    TextStyle? labelStyle,
    TextStyle? valueStyle,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: labelStyle ?? const TextStyle(fontSize: 14)),
            Text(
              value,
              style:
                  valueStyle ??
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      height: 150,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          color: colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Provider.of<BillBreakdownProvider>(
                context,
                listen: false,
              ).reset();
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

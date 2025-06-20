import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/admin_dashboard_service.dart';
import '../widgets/app_drawer.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const routeName = '/admin-dashboard';

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final AdminDashboardService _dashboardService = AdminDashboardService();
  bool _isLoading = true;
  Map<String, dynamic> _dashboardStats = {};
  Map<String, dynamic> _monthlyStats = {};
  Map<String, dynamic> _userPerformance = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dashboardStats = await _dashboardService.getDashboardStats();
      final monthlyStats = await _dashboardService.getMonthlyStats();
      final userPerformance = await _dashboardService.getUserPerformance();

      setState(() {
        _dashboardStats = dashboardStats;
        _monthlyStats = monthlyStats;
        _userPerformance = userPerformance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading dashboard data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.trending_up), text: 'Monthly Trends'),
            Tab(icon: Icon(Icons.people), text: 'User Performance'),
          ],
        ),
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildMonthlyTrendsTab(),
                _buildUserPerformanceTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadDashboardData,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final notesByStatus = _dashboardStats['notesByStatus'] as Map<String, dynamic>? ?? {};
    final usersByRole = _dashboardStats['usersByRole'] as Map<String, dynamic>? ?? {};
    
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Summary Statistics'),
            SizedBox(height: 16),
            _buildStatCards(),
            SizedBox(height: 24),
            
            _buildSectionTitle('Notes by Status'),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: _buildStatusPieChart(notesByStatus),
            ),
            SizedBox(height: 24),
            
            _buildSectionTitle('Users by Role'),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: _buildRolePieChart(usersByRole),
            ),
            SizedBox(height: 24),
            
            _buildSectionTitle('Process Metrics'),
            SizedBox(height: 16),
            _buildProcessMetricsCard(),
            SizedBox(height: 24),
            
            _buildSectionTitle('Notification Metrics'),
            SizedBox(height: 16),
            _buildNotificationMetricsCard(),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyTrendsTab() {
    final notesPerMonth = _monthlyStats['notesPerMonth'] as Map<String, dynamic>? ?? {};
    final statusPerMonth = _monthlyStats['statusPerMonth'] as Map<String, dynamic>? ?? {};
    
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Notes Created per Month'),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: _buildMonthlyBarChart(notesPerMonth),
            ),
            SizedBox(height: 24),
            
            _buildSectionTitle('Status Distribution by Month'),
            SizedBox(height: 16),
            Container(
              height: 400,
              child: _buildMonthlyStatusChart(statusPerMonth),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPerformanceTab() {
    final notesByCreator = _userPerformance['notesByCreator'] as Map<String, dynamic>? ?? {};
    final notesByChefBase = _userPerformance['notesByChefBase'] as Map<String, dynamic>? ?? {};
    final notesByChargeExploitation = _userPerformance['notesByChargeExploitation'] as Map<String, dynamic>? ?? {};
    final notesByAssignee = _userPerformance['notesByAssignee'] as Map<String, dynamic>? ?? {};
    
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Notes Created by User'),
            SizedBox(height: 16),
            _buildUserPerformanceCard('Chef d\'exploitation', notesByCreator),
            SizedBox(height: 24),
            
            _buildSectionTitle('Notes Validated by Chef de Base'),
            SizedBox(height: 16),
            _buildUserPerformanceCard('Chef de Base', notesByChefBase),
            SizedBox(height: 24),
            
            _buildSectionTitle('Notes Validated by Charge Exploitation'),
            SizedBox(height: 16),
            _buildUserPerformanceCard('Charge Exploitation', notesByChargeExploitation),
            SizedBox(height: 24),
            
            _buildSectionTitle('Notes Assigned to Charge Consignation'),
            SizedBox(height: 16),
            _buildUserPerformanceCard('Charge Consignation', notesByAssignee),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildStatCards() {
    final notesLast30Days = _dashboardStats['notesLast30Days'] ?? 0;
    final totalNotes = (_dashboardStats['notesByStatus'] as Map<String, dynamic>?)?.values.fold<int>(0, (sum, value) => sum + (value as int)) ?? 0;
    
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Total Notes', totalNotes.toString(), Icons.note, Colors.blue),
        _buildStatCard('Recent Notes', notesLast30Days.toString(), Icons.today, Colors.green),
        _buildStatCard('Validated Notes', _dashboardStats['notesByStatus']?['VALIDATED']?.toString() ?? '0', Icons.check_circle, Colors.orange),
        _buildStatCard('Rejected Notes', _dashboardStats['notesByStatus']?['REJECTED']?.toString() ?? '0', Icons.cancel, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: color),
            SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessMetricsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMetricRow(
              'Average Validation Time',
              '${(_dashboardStats['avgValidationTimeHours'] ?? 0).toStringAsFixed(1)} hours',
              Icons.timer,
            ),
            Divider(),
            _buildMetricRow(
              'Average Consignation Time',
              '${(_dashboardStats['avgConsignationTimeHours'] ?? 0).toStringAsFixed(1)} hours',
              Icons.lock_clock,
            ),
            Divider(),
            _buildMetricRow(
              'Average Deconsignation Time',
              '${(_dashboardStats['avgDeconsignationTimeHours'] ?? 0).toStringAsFixed(1)} hours',
              Icons.lock_open,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationMetricsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMetricRow(
              'Total Notifications',
              '${_dashboardStats['totalNotifications'] ?? 0}',
              Icons.notifications,
            ),
            Divider(),
            _buildMetricRow(
              'Unread Notifications',
              '${_dashboardStats['unreadNotifications'] ?? 0}',
              Icons.mark_email_unread,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).primaryColor),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPieChart(Map<String, dynamic> notesByStatus) {
    List<PieChartSectionData> sections = [];
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
    ];
    
    int i = 0;
    notesByStatus.forEach((status, count) {
      if (count > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[i % colors.length],
            value: count.toDouble(),
            title: '$status\n$count',
            radius: 80,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        i++;
      }
    });
    
    return sections.isEmpty
        ? Center(child: Text('No data available'))
        : PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          );
  }

  Widget _buildRolePieChart(Map<String, dynamic> usersByRole) {
    List<PieChartSectionData> sections = [];
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
    ];
    
    int i = 0;
    usersByRole.forEach((role, count) {
      if (count > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[i % colors.length],
            value: count.toDouble(),
            title: '$role\n$count',
            radius: 80,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        i++;
      }
    });
    
    return sections.isEmpty
        ? Center(child: Text('No data available'))
        : PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          );
  }

  Widget _buildMonthlyBarChart(Map<String, dynamic> notesPerMonth) {
    if (notesPerMonth.isEmpty) {
      return Center(child: Text('No data available'));
    }
    
    List<BarChartGroupData> barGroups = [];
    List<String> months = [];
    
    // Sort months chronologically
    List<String> sortedMonths = notesPerMonth.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    
    int i = 0;
    for (String month in sortedMonths) {
      months.add(month);
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (notesPerMonth[month] ?? 0).toDouble(),
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
      i++;
    }
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: barGroups.fold<double>(0, (max, group) => 
          group.barRods.first.toY > max ? group.barRods.first.toY + 2 : max),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                String text = '';
                if (value == 0) text = '0';
                else if (value % 5 == 0) text = value.toInt().toString();
                
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 5,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildMonthlyStatusChart(Map<String, dynamic> statusPerMonth) {
    if (statusPerMonth.isEmpty) {
      return Center(child: Text('No data available'));
    }
    
    // Extract all possible statuses
    Set<String> allStatuses = {};
    statusPerMonth.forEach((month, statusMap) {
      (statusMap as Map<String, dynamic>).keys.forEach((status) {
        allStatuses.add(status);
      });
    });
    
    // Sort months chronologically
    List<String> months = statusPerMonth.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: months.length,
      itemBuilder: (context, index) {
        String month = months[index];
        Map<String, dynamic> statusMap = statusPerMonth[month] ?? {};
        
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                ...allStatuses.map((status) {
                  final count = statusMap[status] ?? 0;
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(status),
                        ),
                        Expanded(
                          flex: 6,
                          child: LinearProgressIndicator(
                            value: count > 0 ? 1.0 : 0.0,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStatusColor(status),
                            ),
                            minHeight: 10,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          count.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserPerformanceCard(String roleTitle, Map<String, dynamic> userPerformance) {
    if (userPerformance.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('No data available')),
        ),
      );
    }
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...userPerformance.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: LinearProgressIndicator(
                        value: entry.value > 0 ? 1.0 : 0.0,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                        minHeight: 10,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      entry.value.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'DRAFT':
        return Colors.grey;
      case 'PENDING_CHEF_BASE':
        return Colors.blue;
      case 'PENDING_CHARGE_EXPLOITATION':
        return Colors.orange;
      case 'VALIDATED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }
}

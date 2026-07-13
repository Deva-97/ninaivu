import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ninaivu/domain/entities/policy.dart';

class SearchablePolicyPicker extends StatelessWidget {
  const SearchablePolicyPicker({
    super.key,
    required this.label,
    required this.selectedPolicy,
    required this.onSearch,
    required this.onChanged,
    this.onClear,
    this.enabled = true,
  });

  final String label;
  final Policy? selectedPolicy;
  final Future<List<Policy>> Function(String query) onSearch;
  final ValueChanged<Policy> onChanged;
  final VoidCallback? onClear;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return InkWell(
      onTap: !enabled
          ? null
          : () async {
              final selected = await showDialog<Policy>(
                context: context,
                builder: (_) => _PolicySearchDialog(onSearch: onSearch),
              );
              if (selected != null) {
                onChanged(selected);
              }
            },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: selectedPolicy == null
              ? const Icon(Icons.search)
              : IconButton(onPressed: onClear, icon: const Icon(Icons.clear)),
        ),
        child: selectedPolicy == null
            ? Text(
                enabled
                    ? 'Select a policy (optional)'
                    : 'Select a client first',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedPolicy!.policyNumber,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${selectedPolicy!.companyName} • ${selectedPolicy!.insuranceType}',
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Expiry: ${dateFormat.format(DateTime.fromMillisecondsSinceEpoch(selectedPolicy!.endDate))}',
                  ),
                ],
              ),
      ),
    );
  }
}

class _PolicySearchDialog extends StatefulWidget {
  const _PolicySearchDialog({required this.onSearch});

  final Future<List<Policy>> Function(String query) onSearch;

  @override
  State<_PolicySearchDialog> createState() => _PolicySearchDialogState();
}

class _PolicySearchDialogState extends State<_PolicySearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  List<Policy> _results = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Dialog search lets follow-up forms filter policies by selected client.
  Future<void> _load([String query = '']) async {
    setState(() => _isLoading = true);
    final items = await widget.onSearch(query);
    if (!mounted) {
      return;
    }
    setState(() {
      _results = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Policy'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by policy number or company',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: () => _load(_searchController.text.trim()),
                  icon: const Icon(Icons.arrow_forward),
                ),
              ),
              onSubmitted: _load,
            ),
            const SizedBox(height: 12),
            Flexible(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                  ? const Center(child: Text('No policies found'))
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _results.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final policy = _results[index];
                        return ListTile(
                          title: Text(policy.policyNumber),
                          subtitle: Text(
                            '${policy.companyName} • ${policy.insuranceType}\n'
                            'Expiry: ${_dateFormat.format(DateTime.fromMillisecondsSinceEpoch(policy.endDate))}',
                          ),
                          isThreeLine: true,
                          onTap: () => Navigator.of(context).pop(policy),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

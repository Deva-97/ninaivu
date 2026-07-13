import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ninaivu/core/constants/translation_keys.dart';
import 'package:ninaivu/domain/entities/client.dart';

class SearchableClientPicker extends StatelessWidget {
  const SearchableClientPicker({
    super.key,
    required this.label,
    required this.selectedClient,
    required this.onSearch,
    required this.onChanged,
    this.errorText,
    this.helperText,
    this.initialQuery,
  });

  final String label;
  final Client? selectedClient;
  final Future<List<Client>> Function(String query) onSearch;
  final ValueChanged<Client> onChanged;
  final String? errorText;
  final String? helperText;
  final String? initialQuery;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selected = await showDialog<Client>(
          context: context,
          builder: (_) => _ClientSearchDialog(
            onSearch: onSearch,
            initialQuery: initialQuery,
          ),
        );
        if (selected != null) {
          onChanged(selected);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          helperText: helperText,
          suffixIcon: const Icon(Icons.search),
        ),
        child: selectedClient == null
            ? Text(TranslationKeys.selectClient.tr)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedClient!.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      selectedClient!.mobile,
                      if ((selectedClient!.areaCity ?? '').trim().isNotEmpty)
                        selectedClient!.areaCity!,
                    ].join(' • '),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ClientSearchDialog extends StatefulWidget {
  const _ClientSearchDialog({required this.onSearch, this.initialQuery});

  final Future<List<Client>> Function(String query) onSearch;
  final String? initialQuery;

  @override
  State<_ClientSearchDialog> createState() => _ClientSearchDialogState();
}

class _ClientSearchDialogState extends State<_ClientSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Client> _results = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery?.trim() ?? '';
    _load(_searchController.text.trim());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Dialog-level search keeps the form widget reusable and lightweight.
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
      title: Text(TranslationKeys.selectClient.tr),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: TranslationKeys.searchByNameOrMobile.tr,
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
                  ? Center(child: Text(TranslationKeys.noClientsFound.tr))
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _results.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final client = _results[index];
                        return ListTile(
                          title: Text(client.name),
                          subtitle: Text(
                            [
                              client.mobile,
                              if ((client.areaCity ?? '').trim().isNotEmpty)
                                client.areaCity!,
                            ].join(' • '),
                          ),
                          onTap: () => Navigator.of(context).pop(client),
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
          child: Text(TranslationKeys.close.tr),
        ),
      ],
    );
  }
}

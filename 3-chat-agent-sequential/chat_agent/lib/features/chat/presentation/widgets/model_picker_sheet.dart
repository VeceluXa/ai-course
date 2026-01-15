import 'package:flutter/material.dart';

import '../../../../core/utils/debounce.dart';
import '../../domain/entities/model_info.dart';

class ModelPickerSheet extends StatefulWidget {
  const ModelPickerSheet({
    super.key,
    required this.models,
    required this.recommendedModels,
    required this.selectedModelId,
    required this.onSelected,
  });

  final List<ModelInfo> models;
  final List<ModelInfo> recommendedModels;
  final String? selectedModelId;
  final ValueChanged<ModelInfo> onSelected;

  @override
  State<ModelPickerSheet> createState() => _ModelPickerSheetState();
}

class _ModelPickerSheetState extends State<ModelPickerSheet> {
  final _searchController = TextEditingController();
  late final Debouncer _debouncer;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(delay: const Duration(milliseconds: 250));
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debouncer.run(() {
      setState(() {
        _query = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredModels = _filter(widget.models);
    final filteredRecommended = _filter(widget.recommendedModels);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search models',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  if (filteredRecommended.isNotEmpty) ...[
                    _sectionHeader(context, 'Recommended'),
                    ...filteredRecommended.map((model) => _modelTile(context, model)),
                    const SizedBox(height: 12),
                  ],
                  _sectionHeader(context, 'All models'),
                  if (filteredModels.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No models match your search.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  else
                    ...filteredModels.map((model) => _modelTile(context, model)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ModelInfo> _filter(List<ModelInfo> models) {
    if (_query.isEmpty) return models;
    return models
        .where((model) =>
            model.displayName.toLowerCase().contains(_query) ||
            model.id.toLowerCase().contains(_query))
        .toList();
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(title, style: Theme.of(context).textTheme.titleSmall),
      ),
    );
  }

  Widget _modelTile(BuildContext context, ModelInfo model) {
    final selected = model.id == widget.selectedModelId;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(model.displayName),
      subtitle: Text(model.id),
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: () {
        widget.onSelected(model);
        Navigator.of(context).pop();
      },
    );
  }
}

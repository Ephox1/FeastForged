import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/utils/error_messages.dart';
import '../../../../shared/utils/validators.dart';
import '../../providers/household_provider.dart';

class HouseholdMembersScreen extends ConsumerWidget {
  const HouseholdMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(householdMembersProvider);

    ref.listen(householdEditorProvider, (_, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorMessages.friendly(next.error))),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Household members')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMemberDialog(context, ref),
        icon: const Icon(Icons.person_add_alt_1_outlined),
        label: const Text('Add member'),
      ),
      body: members.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load members: $error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No household members yet. Add people here when you are ready for multi-person planning.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: items
                .map(
                  (member) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(member.name),
                      subtitle: Text(
                        member.age == null
                            ? 'No age set'
                            : 'Age ${member.age}',
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }

  Future<void> _showAddMemberDialog(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final ageController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add household member'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                      Validators.required(value, fieldName: 'Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Age (optional)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    return Validators.positiveNumber(value, fieldName: 'Age');
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                await ref
                    .read(householdEditorProvider.notifier)
                    .addMember(
                      name: nameController.text,
                      age: ageController.text.trim().isEmpty
                          ? null
                          : int.parse(ageController.text.trim()),
                    );
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    ageController.dispose();
  }
}

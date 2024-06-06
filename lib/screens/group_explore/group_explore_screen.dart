import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:refactoring/models/group_model.dart';
import 'package:refactoring/screens/group_chat/group_chat_screen.dart';
import 'package:refactoring/view_models/group_view_model.dart';
import 'package:refactoring/view_models/user_view_model.dart';
import 'package:refactoring/widgets/shared/custom_app_bar.dart';
import 'package:refactoring/widgets/shared/custom_list_tile.dart';

class GroupExploreScreen extends StatefulWidget {
  const GroupExploreScreen({super.key});

  @override
  State<GroupExploreScreen> createState() => _GroupExploreScreenState();
}

class _GroupExploreScreenState extends State<GroupExploreScreen> {
  bool isTyping = false;

  void createGroup(UserViewModel userModel, GroupViewModel groupModel) {
    showDialog(
      context: context,
      builder: (context) {
        final key = GlobalKey<FormState>();
        final groupNameController = TextEditingController();
        final descriptionController = TextEditingController();

        return AlertDialog(
          title: const Text(
            'Create new group',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: key,
            child: SizedBox(
              height: 130,
              child: Column(
                children: [
                  TextFormField(
                    controller: groupNameController,
                    validator: (value) {
                      return value == null || value.isEmpty
                          ? "Group name can't be empty"
                          : null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter group name..',
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Enter group description..',
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (key.currentState!.validate()) {
                  Navigator.of(context).pop();
                  saveGroup(
                    groupNameController.text,
                    descriptionController.text,
                    userModel,
                    groupModel,
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void saveGroup(
    String name,
    String description,
    UserViewModel userModel,
    GroupViewModel groupModel,
  ) {
    groupModel.createGroup(name, description).then((message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
      userModel.fetchUser();
    });
  }

  void parcipate(
    GroupModel group,
    UserViewModel userModel,
    GroupViewModel groupModel,
  ) {
    final optional = userModel.user!.participateGroups
        .where((element) => element.name == group.name)
        .firstOrNull;
    if (optional != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GroupChatScreen(group: group),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: const Text(
              'Would you like to join this group?',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await saveMember(groupModel, userModel, group);
                },
                child: const Text('Yes'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> saveMember(
    GroupViewModel groupModel,
    UserViewModel userModel,
    GroupModel group,
  ) async {
    final message = await groupModel.saveMember(group.name);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    userModel.fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserViewModel>(context, listen: false);

    return Consumer<GroupViewModel>(
      builder: (context, groupModel, child) {
        var groups = groupModel.groups;
        return Scaffold(
          appBar: isTyping
              ? AppBar(
                  leading: IconButton(
                    onPressed: () => setState(() {
                      isTyping = false;
                    }),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  title: SizedBox(
                    height: 45,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search for groups..',
                        border: UnderlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          groups = groupModel.filter(value);
                        });
                      },
                    ),
                  ),
                )
              : CustomAppBar(
                  isMainScreen: false,
                  title: 'Explorer',
                  actions: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isTyping = true;
                        });
                      },
                      icon: const Icon(Icons.search),
                    ),
                    PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {},
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            value: 1,
                            child: Text(
                              'View created groups',
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 2,
                            child: Text(
                              'View participate groups',
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ),
                          const PopupMenuItem(
                            value: 3,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.close),
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
          body: groups.isEmpty
              ? const Center(
                  child: Text(
                    'No groups created yet, be the first to create',
                  ),
                )
              : ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return group.picture != null
                        ? CustomListTile(
                            isLeadingImage: true,
                            leading: group.picture!,
                            title: group.name,
                            subtitle: group.description,
                            onTap: () => parcipate(
                              group,
                              userModel,
                              groupModel,
                            ),
                          )
                        : CustomListTile(
                            isLeadingImage: false,
                            leading: group.name.substring(0, 1),
                            title: group.name,
                            subtitle: group.description,
                            onTap: () => parcipate(
                              group,
                              userModel,
                              groupModel,
                            ),
                          );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => createGroup(userModel, groupModel),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

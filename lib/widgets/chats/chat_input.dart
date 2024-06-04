import 'package:flutter/material.dart';
import 'package:refactoring/widgets/shared/modal_bottom_sheet_action.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final List<ModalBottomSheetAction> actions;
  final Function(String value) onChanged;
  final void Function() onPressed;
  final ValueNotifier<bool> typingNotifier;
  final ValueNotifier<bool> recordingNotifier;

  const ChatInput({
    super.key,
    required this.controller,
    required this.actions,
    required this.onChanged,
    required this.typingNotifier,
    required this.recordingNotifier,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([typingNotifier, recordingNotifier]),
      builder: (context, child) {
        return Container(
          height: 90,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 0.2,
                color: Colors.grey,
              ),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  width: 300,
                  child: TextField(
                    controller: controller,
                    autocorrect: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Send a message...',
                    ),
                    onChanged: onChanged,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: actions,
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.attach_file),
                ),
                IconButton(
                  onPressed: onPressed,
                  icon: Icon(
                    recordingNotifier.value
                        ? Icons.stop
                        : (typingNotifier.value ? Icons.send : Icons.mic),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

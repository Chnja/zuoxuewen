import 'package:flutter/material.dart';

class CCheckbox extends StatelessWidget {
  const CCheckbox({
    super.key,
    required this.title,
    this.subtitle,
    this.order,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final Function onChanged;
  final int? order;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: <Widget>[
            const SizedBox(
              width: 5,
            ),
            Checkbox(
              value: value,
              onChanged: (bool? newValue) {
                onChanged(newValue);
              },
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ((order != null && order! > 0)
                        ? Text("顺序$order ",
                            style: const TextStyle(
                                fontSize: 13,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold))
                        : Container()),
                    Text(
                      subtitle!,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 1,
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 15),
                )
              ],
            )),
          ],
        ),
      ),
    );
  }
}

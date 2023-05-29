import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:daily_organiser/provider.dart';
import 'package:daily_organiser/database/trackermodel.dart';
import 'package:daily_organiser/database/statsmodel.dart';
import 'package:daily_organiser/screens/tracker/trackerpopup.dart';

class EditStatsPopup extends StatefulWidget {
  const EditStatsPopup({
    super.key,
    required this.theme,
    required this.trackerInfo,
    required this.stat,
  });

  final ThemeData theme;
  final Tracker trackerInfo;
  final Stat stat;

  @override
  State<EditStatsPopup> createState() => _EditStatsPopup();
}

class _EditStatsPopup extends State<EditStatsPopup> {
  bool isLoading = false;
  late DateTime chosenTime;
  final _valueController = TextEditingController();

  // KEY FOR VALIDATION OF THE FORM
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    chosenTime = DateTime.utc(
      widget.stat.year,
      widget.stat.month,
      widget.stat.day,
    );

    _valueController.text = widget.stat.value.toString();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.stat.year} / ${widget.stat.month} / ${widget.stat.day}',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HeaderText(widget: widget, header: 'VALUE'),

                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _valueController,
                  onTap: () => _valueController.clear(),
                  validator: (String? value) {
                    return (int.tryParse(value!) == null && value != null)
                        ? 'Please enter a number'
                        : null;
                  },
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Value',
                      suffixIcon: IconButton(
                        onPressed: () => _valueController.clear(),
                        icon: const Icon(Icons.clear),
                      )),
                ),

                // SUBMIT BUTTON FOR SUBMITING NEW TRACKER
                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(50)),
                  onPressed: () {
                    final isValidForm = formKey.currentState!.validate();

                    if (isValidForm) {
                      var newStat = Stat(
                        id: widget.stat.id,
                        tracker_id: widget.trackerInfo.id!,
                        year: widget.stat.year,
                        month: widget.stat.month,
                        day: widget.stat.day,
                        value: stringToInt(_valueController).toDouble(),
                      );
                      setState(() {
                        appState.updateStat(newStat);
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text(
                    'SUBMIT',
                    style: TextStyle(letterSpacing: 2),
                  ),
                ),
                SizedBox(height: 10)
              ],
            ),
          ),
        ),
      ),
    );
  }

  int stringToInt(TextEditingController controllerExample) {
    int? rangeValue = int.tryParse(controllerExample.text);
    int defaultValue = 10;

    if (rangeValue != null) {
      return rangeValue;
    } else {
      return defaultValue;
    }
  }
}
import 'package:flutter/material.dart';

import '../components/constance.dart';
import '../components/time.dart';
import '../crud/database_entry.dart';
import '../crud/notes_services.dart';
import '../widgets/rounded_button.dart';

class CashCard extends StatefulWidget {
  const CashCard({super.key, required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  State<CashCard> createState() => _CashCardState();
}

class _CashCardState extends State<CashCard> {
  final EntryService _entryService = EntryService();
  final formKey = GlobalKey<FormState>();
  DateTime time = DateTime.now();

  String? formattedTime;
  int? rwTime;
  int? amount;
  String? remark;
  EntryType? type;

  @override
  void initState() {
    formattedTime = Time.getFormatted(time);
    rwTime = Time.getRawTime(time);
    type = widget.text == 'Cash In' ? EntryType.cashIn : EntryType.cashOut;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    bool valid = false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 45),
            child: Container(
              height: mq.size.width <= 400
                  ? mq.size.height * 0.45
                  : mq.size.height * 0.48,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF27496D),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SizedBox(
                            child: FittedBox(
                              child: Text(widget.text, style: widget.style),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () async => await showMyDatePicker(
                              ctx: context,
                              initialdate: time,
                              onDateTimeChanged: (D) => setState(() {
                                formattedTime = Time.getFormatted(D);
                                rwTime = D.millisecondsSinceEpoch;
                              }),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF3b6fa5),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.calendar_month, size: 26),
                                  const SizedBox(width: 10),
                                  FittedBox(
                                    child: Text(
                                      formattedTime!,
                                      style: TextStyle(
                                        fontSize:
                                            mq.size.width >= 400 ? 20 : 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: SizedBox(
                        child: Container(
                          height: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Text(
                      'Amount',
                      style: kAmountTextStyle,
                    ),
                    TextFormField(
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Enter some amount';
                        }
                        if (int.tryParse(v) == null) {
                          return 'Enter a number';
                        }
                        return null;
                      },
                      onSaved: (v) => amount = int.tryParse(v!),
                      autofocus: true,
                      style: kInputTextStyle,
                      decoration: kAmountTextFieldDecoration,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                    TextFormField(
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Entere some remark';
                        }
                        return null;
                      },
                      onSaved: (v) => remark = v,
                      maxLines: 4,
                      style: kInputTextStyle,
                      decoration: kRemarkTextFieldDecoration,
                      textInputAction: TextInputAction.done,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 2,
                          child: RoundedButton(
                            text: 'CREATE',
                            style: kRoundedButtonTextStyle,
                            color: Colors.teal,
                            onPressed: () async {
                              valid = formKey.currentState!.validate();
                              if (!valid) return;
                              formKey.currentState!.save();
                              _entryService.createEntry(
                                remark: remark!,
                                amount: amount!,
                                type: type!.name,
                                time: formattedTime!,
                                rwTime: rwTime!,
                              );
                              kFlutterToast('Entry Created !!');
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        const Expanded(child: CancelButton())
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Material(
        elevation: 5,
        color: Colors.red,
        borderRadius: BorderRadius.circular(30),
        child: MaterialButton(
          height: 42,
          minWidth: 10,
          onPressed: () => Navigator.pop(context),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: const Icon(Icons.close, size: 18),
        ),
      ),
    );
  }
}

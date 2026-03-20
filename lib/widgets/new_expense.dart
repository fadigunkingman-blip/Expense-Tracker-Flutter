import 'package:expense_app/main.dart';
import 'package:expense_app/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewExpense extends StatefulWidget {
  const NewExpense({super.key, required this.addNewExpense});
  final void Function(Expense expenseData) addNewExpense;

  @override
  State<NewExpense> createState() {
    return _NewExpenseState();
  }
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.food;
  EntryType _selectedType = EntryType.expense;

  void _submitExpenseData() {
    final enteredAmount = double.tryParse(_amountController.text.trim());
    if (_titleController.text.trim().isEmpty ||
        enteredAmount == null ||
        enteredAmount <= 0 ||
        _selectedDate == null) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: const Text("Invalid input"),
                content: const Text(
                    "Please make sure a valid title, amount, date and category was entered."),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Close"))
                ],
              ));
      return;
    }
    widget.addNewExpense(Expense(
        title: _titleController.text,
        amount: enteredAmount,
        date: _selectedDate!,
        category: _selectedCategory,
        type: _selectedType));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: firstDate,
        lastDate: now);
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 24, 16, keyboardSpace + 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Income / Expense toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5EE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _typeToggle(
                    label: 'Expense',
                    icon: Icons.arrow_upward_rounded,
                    type: EntryType.expense,
                    activeColor: kExpenseColor,
                  ),
                  _typeToggle(
                    label: 'Income',
                    icon: Icons.arrow_downward_rounded,
                    type: EntryType.income,
                    activeColor: kIncomeColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              maxLength: 50,
              decoration: const InputDecoration(
                label: Text("Title"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))
                    ],
                    decoration: const InputDecoration(
                      label: Text("Amount"),
                      prefixText: '\$',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _selectedDate == null
                            ? "No Date"
                            : formatter.format(_selectedDate!),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      IconButton(
                          onPressed: _presentDatePicker,
                          icon: const Icon(Icons.calendar_month_rounded))
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                DropdownButton(
                    value: _selectedCategory,
                    items: Category.values
                        .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.name.toUpperCase())))
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedCategory = value;
                      });
                    }),
                const Spacer(),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                const SizedBox(width: 8),
                ElevatedButton(
                    onPressed: _submitExpenseData,
                    child: Text(_selectedType == EntryType.income
                        ? 'Save Income'
                        : 'Save Expense')),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _typeToggle({
    required String label,
    required IconData icon,
    required EntryType type,
    required Color activeColor,
  }) {
    final isActive = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: isActive ? Colors.white : Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isActive ? Colors.white : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

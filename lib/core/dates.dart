const monthsPtBr = <String>[
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

DateTime firstDayOfMonth(DateTime date) => DateTime(date.year, date.month);
DateTime nextMonth(DateTime date) => DateTime(date.year, date.month + 1);
String monthLabel(DateTime date) => '${monthsPtBr[date.month - 1]} ${date.year}';
String dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
String prettyDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';

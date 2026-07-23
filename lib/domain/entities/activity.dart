enum Activity {
  walk('Balade'),
  run('Course'),
  picnic('Pique-nique'),
  golf('Golf'),
  tennis('Tennis');

  const Activity(this.label);

  final String label;
}

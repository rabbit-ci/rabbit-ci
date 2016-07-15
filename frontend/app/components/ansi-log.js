import Ember from 'ember';

export default Ember.Component.extend({
  columns: [100],

  groupedLogs: Ember.computed('logs.[]', function() {
    var t2 = performance.now();

    let lines = [];
    let currentLine = [];

    this.get('logs').forEach(function(log, _index, _enumerable) {
      currentLine.push(log);
      let stdio = log.stdio;
      if (stdio.charAt(stdio.length - 1) === "\n") {
        lines.push(currentLine);
        currentLine = [];
      }
    });
    lines.push(currentLine);

    var t3 = performance.now();
    console.log("Update groupedLogs took  " + (t3 - t2) + " milliseconds.");

    return lines;
  })
});

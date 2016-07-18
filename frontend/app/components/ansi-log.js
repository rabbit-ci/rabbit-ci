import Ember from 'ember';

export default Ember.Component.extend({
  columns: [100],

  groupedLogs: Ember.computed('logs.[]', function() {
    var t2 = performance.now();

    let lines = [];
    let currentLine = [];
    let carriageReturn = false;
    let cursorPos = 0;

    this.get('logs').forEach(function(log, _index, _enumerable) {
      let stdio = log.stdio;
      let lastChar = stdio.charAt(stdio.length - 1);

      if (carriageReturn) {
        if (stdio.replace("\r", "").replace("\n", "").length > 0) {
          currentLine = [log];
        } else {
          currentLine.push(log);
        }

        carriageReturn = false;
      } else {
        currentLine.push(log);
      }

      if (lastChar === "\r") {
        carriageReturn = true;
      }

      if (lastChar === "\n") {
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

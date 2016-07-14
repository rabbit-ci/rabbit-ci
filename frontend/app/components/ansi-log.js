import Ember from 'ember';

export default Ember.Component.extend({
  oneWaySortedLogs: Ember.computed.oneWay("sortedLogs"),
  columns: [100],

  groupedLogs: Ember.computed('oneWaySortedLogs', function() {
    let lines = [];
    let currentLine = [];

    this.get('oneWaySortedLogs').forEach(function(log, _index, _enumerable) {
      currentLine.push(log);
      if (log.get('endsInNewline') === true) {
        lines.push(currentLine);
        currentLine = [];
      }
    });

    return lines;
  })
});

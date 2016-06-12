import Ember from 'ember';

export default Ember.Component.extend({
  logSorting: ['order'],
  sortedLogs: Ember.computed.sort('logs', 'logSorting')
});

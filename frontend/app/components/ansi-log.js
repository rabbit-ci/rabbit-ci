import Ember from 'ember';

export default Ember.Component.extend({
  logLines: Ember.computed('rawLog', function() {
    if (!this.get('rawLog')) return ["loading..."];
    return "<a class=\"line-number\"></a>" +
      this.get('rawLog')
      .replace(/\r\n/g, "\n")
      .replace(/\r/g, "\n")
      .split("\n")
      .join("\n<a class=\"line-number\"></a>");
  })
});

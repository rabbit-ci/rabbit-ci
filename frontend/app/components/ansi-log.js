import Ember from 'ember';
import ansi_up from 'npm:ansi_up';

export default Ember.Component.extend({
  logLines: Ember.computed('rawLog', function() {
    if (!this.get('rawLog')) return ["loading..."];
    return "<a class=\"line-number\"></a>" +
      ansi_up.ansi_to_html(this.get('rawLog'), {use_classes: true})
      .replace(/\r\n/g, "\n")
      .replace(/\r/g, "\n")
      .split("\n")
      .join("\n<a class=\"line-number\"></a>");
  })
});

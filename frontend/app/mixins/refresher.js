import Ember from 'ember';

export default Ember.Mixin.create({
  setupController(controller, model) {
    this._super(controller, model);
    this.startRefreshing();
  },

  startRefreshing() {
    Em.run.later(this, this.doRefresh, 1000);
  },

  doRefresh() {
    this.refresh();
    Em.run.later(this, this.doRefresh, 1000);
  }
});

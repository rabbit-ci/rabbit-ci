import Ember from 'ember';

export default Ember.Mixin.create({
  refreshInterval: 1000,
  setupController(controller, model) {
    this._super(controller, model);
    this.startRefreshing();
  },

  startRefreshing() {
    this.set('refreshing', true);
    Em.run.later(this, this.doNextRefresh, this.get('refreshInterval'));
  },

  doNextRefresh() {
    if(!this.get('refreshing'))
      return;
    if(this.get('shouldRefresh') !== false) {
      this.doRefresh();
      this.set('refreshing', true);
    }
    Em.run.later(this, this.doNextRefresh, this.get('refreshInterval'));
  },

  doRefresh() {
    this.refresh();
  },

  actions: {
    willTransition(){
      this.set('refreshing', false);
    }
  }
});

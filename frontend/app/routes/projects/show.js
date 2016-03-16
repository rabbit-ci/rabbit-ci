import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.queryRecord('project', {name: params.owner + "/" + params.repo});
  },

  serialize(model, params) {
    return {
      owner: model.get("owner"),
      repo: model.get("repo")
    };
  }
});

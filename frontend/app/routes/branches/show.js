import Ember from 'ember';
import flatten from 'rabbit-ci/utils/flatten';

export default Ember.Route.extend({
  model(params) {
    return this.store.queryRecord("branch", {
      branch: decodeURIComponent(params.branch_name),
      project: this.modelFor('projects.show').get('name')
    });
  },

  serialize(model, params) {
    return {
      owner: model.get("project.owner"),
      repo_name: model.get("project.repo_name"),
      branch_name: encodeURIComponent(model.get("name"))
    };
  },

  afterModel(branch) {
    Ember.addObserver(branch, 'builds', this, '_subscribeRecords');
    this._subscribeRecords(branch);

    if (branch.get('builds').isFulfilled === true) {
      branch.get('builds').reload();
    }
  },

  phoenix: Ember.inject.service(),
  idMap: {},

  _subscribeRecords() {
    let branch = arguments[0] || this.get('currentModel');
    if (!branch) return;

    let oldIds = Ember.copy(this.get('idMap'), true);
    this.set('idMap', {});

    this.set('idMap.branches', branch.get('id'));
    this.set('idMap.builds', branch.get('builds').mapBy('id'));

    let jobIds = flatten(branch.get('builds').map((build) => {
      return build.get('steps').map((step) => {
        return step.get('jobs').mapBy('id');
      });
    }));

    this.set('idMap.jobs', jobIds);

    this.get('phoenix').subscribe(this.get('idMap'));
    this.get('phoenix').unsubscribe(oldIds);
  },

  deactivate() {
    Ember.removeObserver(this.get('currentModel'), 'builds', this, '_subscribeRecords');
    this.get('phoenix').unsubscribe(this.get('idMap'));
    this.set('idMap', {});
  }
});

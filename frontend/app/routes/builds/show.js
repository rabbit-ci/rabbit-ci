import Ember from 'ember';
import flatten from 'rabbit-ci/utils/flatten';

export default Ember.Route.extend({
  model(params) {
    return this.store.queryRecord("build", {
      branch: decodeURIComponent(params.branch_name),
      project: this.modelFor('projects.show').get('name'),
      build_number: params.build_number
    });
  },

  serialize(model, params) {
    return {
      owner: model.get("branch.project.owner"),
      repo_name: model.get("branch.project.repo_name"),
      branch_name: encodeURIComponent(model.get("branch.name")),
      build_number: model.get("buildNumber")
    };
  },

  phoenix: Ember.inject.service(),
  idMap: {},

  afterModel(build) {
    Ember.addObserver(build, 'steps', this, '_subscribeRecords');
    this._subscribeRecords(build);
  },

  _subscribeRecords() {
    let build = arguments[0] || this.get('currentModel');
    if (!build) return;

    let oldIds = Ember.copy(this.get('idMap'), true);
    this.set('idMap', {});
    this.set('idMap.builds', build.get('id'));

    let jobIds = flatten(build.get('steps').map((step) => {
      return step.get('jobs').mapBy('id');
    }));

    this.set('idMap.jobs', jobIds);
    this.set('idMap.logs', jobIds);

    this.get('phoenix').subscribe(this.get('idMap'));
    this.get('phoenix').unsubscribe(oldIds);
  },

  deactivate() {
    Ember.removeObserver(this.get('currentModel'), 'steps', this, '_subscribeRecords');
    this.get('phoenix').unsubscribe(this.get('idMap'));
    this.set('idMap', {});
  }
});

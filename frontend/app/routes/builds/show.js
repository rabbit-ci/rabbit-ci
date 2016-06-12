import Ember from 'ember';

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
  idMap: {builds: null, jobs: []},
  // TODO: Handle new jobs being loaded.
  afterModel(build) {
    this.set('idMap.jobs', []);
    this.set('idMap.builds', build.get('id'));

    build.get('steps').forEach((step) => {
      step.get('jobs').forEach((job) => {
        this.set('idMap.jobs', this.get('idMap.jobs').concat(job.get('id')));
        this.set('idMap.logs', this.get('idMap.jobs').concat(job.get('id')));
      });
    });

    this.get('phoenix').subscribe(this.get('idMap'));
  },

  deactivate() {
    this.get('phoenix').unsubscribe(this.get('idMap'));
  }
});

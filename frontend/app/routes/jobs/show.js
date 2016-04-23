import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    // The parent route already loaded the job.
    return this.store.peekRecord('job', params.job_id);
  },

  serialize(model, params) {
    return {
      owner: model.get("step.build.branch.project.owner"),
      repo_name: model.get("step.build.branch.project.repo_name"),
      branch_name: encodeURIComponent(model.get("step.build.branch.name")),
      build_number: model.get("step.build.buildNumber"),
      job_id: model.get("id")
    };
  }
});

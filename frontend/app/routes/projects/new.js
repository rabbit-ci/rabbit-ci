import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return this.store.createRecord('project');
  },

  actions: {
    save(project) {
      project.save().then((savedProject) => {
        this.transitionTo('projects.show', savedProject);
      });
    }
  }
});

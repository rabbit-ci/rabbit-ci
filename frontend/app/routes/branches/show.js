import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.queryRecord("branch", {
      branch: params.branch_name,
      project: params.project_name
    });
  },

  afterModel(branch) {
    if (branch.get('builds').isFulfilled === true) {
      branch.get('builds').reload()
        .then(builds => this._connectBuildsToChan(builds));
    } else {
      branch.get('builds')
        .then(builds => this._connectBuildsToChan(builds));
    }
  },

  _connectBuildsToChan(builds) {
    builds.forEach((build) => {
      build.connectToChan();
    });
  },

  _disconnectBuildsFromChan(builds) {
    builds.forEach((build) => {
      build.disconnectFromChan();
    });
  },

  actions: {
    willTransition() {
      if (this.get('currentModel.builds')) {
        this.get('currentModel.builds')
          .then((builds) => this._disconnectBuildsFromChan(builds));
      }

      return true;
    }
  }
});

import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('projects', {path: '/'}, function() {
    this.route('index', {path: '/'});
    this.route('show', {path: '/:owner/:repo_name'}, function() {
      this.route('branches.index', {resetNamespace: true, path: '/'});
      this.route('branches.show', {resetNamespace: true, path: '/:branch_name'});
      this.route('builds.show', {resetNamespace: true, path: '/:branch_name/:build_number'});
    });
  });
});

export default Router;

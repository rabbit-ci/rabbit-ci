import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('projects', {path: '/'}, function() {
    this.route('index', {path: '/'});
    this.route("new", {path: '/new'});
    this.route('show', {path: '/:owner/:repo_name'}, function() {
      this.route('branches.index', {resetNamespace: true, path: '/'});
      this.route('branches.show', {resetNamespace: true, path: '/:branch_name'});
      this.route('builds.show', {resetNamespace: true, path: '/:branch_name/:build_number'}, function() {
        this.route("jobs.show", {resetNamespace: true, path: '/:job_id'});
      });
    });
  });
});

export default Router;

import Ember from 'ember';
import config from './config/environment';

const Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.route('projects', {path: '/'}, function() {
    this.route('index', {path: '/'});
    this.route('show', {path: '/:project_name'});
  });

  this.route('branches', {path: ''}, function() {
    this.route('index', {path: '/:project_name/branches'});
    this.route('show', {path: '/:project_name/b/:branch_name'});
  });

  this.route('builds.show', {path: '/:project_name/b/:branch_name/b/:build_number'});
});

export default Router;

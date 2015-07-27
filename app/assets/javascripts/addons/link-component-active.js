activeParent = {
  activeParent: false,
  isActive: false,

  addIsActiveObserver: function () {
    if (this.get('activeParent')) {
      this.addObserver('isActive', this, 'activeObserver');
      this.activeObserver();
    }
  }.on('didInsertElement'),

  activeObserver: function () {
    if (this.get('isActive')) {
      this.$().parent().addClass('active');
    } else {
      this.$().parent().removeClass('active');
    }
  },

  active: Ember.computed('resolvedParams', 'routeArgs', function () {
    var isActive = this._super();

    Ember.set(this, 'isActive', !!isActive);

    return isActive;
  })
};

Ember.LinkComponent.reopen(activeParent);
Cataract.ActiveParentMixin = Ember.Mixin.create(activeParent);

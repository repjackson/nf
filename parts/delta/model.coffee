if Meteor.isClient
    Template.model_view.onCreated ->
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id

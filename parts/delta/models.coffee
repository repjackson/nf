if Meteor.isClient
    Template.model_view.onCreated ->
        @autorun -> Meteor.subscribe 'model', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_fields_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'docs', selected_tags.array(), Router.current().params.model_slug

    Template.model_view.helpers
        current_model: ->
            Router.current().params.model_slug
        model: ->
            Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug

        model_docs: ->
            model = Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug

            Docs.find
                model:model.slug

        model_doc: ->
            model = Docs.findOne
                model:'model'
                slug: Router.current().params.model_slug
            "#{model.slug}_view"

        fields: ->
            Docs.find { model:'field' }, sort:rank:1
                # parent_id: Router.current().params.doc_id

    Template.model_view.events
        'click .add_child': ->
            model = Docs.findOne slug:Router.current().params.model_slug
            console.log model
            # new_id = Docs.insert
            #     model: Router.current().params.model_slug
            # Router.go "/edit/#{new_id}"


if Meteor.isServer
    Meteor.publish 'model', (slug)->
        Docs.find
            model:'model'
            slug:slug

    Meteor.publish 'model_fields_from_slug', (slug)->
        model = Docs.findOne
            model:'model'
            slug:slug
        Docs.find
            model:'field'
            parent_id:model._id

    Meteor.publish 'model_fields_from_id', (model_id)->
        model = Docs.findOne model_id
        Docs.find
            model:'field'
            parent_id:model._id

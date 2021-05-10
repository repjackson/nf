if Meteor.isClient
    Router.route '/m/:model_slug/:doc_id/view', (->
        @render 'model_doc_view'
        ), name:'doc_view'

    Router.route '/m/:model_slug/:doc_id/edit', (->
        @render 'model_doc_edit'
        ), name:'doc_edit'


    Template.model_doc_edit.onCreated ->
        @autorun -> Meteor.subscribe 'me'
        @autorun -> Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'model_fields_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
        @autorun -> Meteor.subscribe 'model_docs', 'field_type'

    Template.model_doc_edit.helpers
        template_exists: ->
            # current_model = Docs.findOne(Router.current().params.doc_id).model
            # unless current_model.model is 'model'
            #     if Template["#{current_model}_edit"]
            #         return true
            #     else
            #         return false
            # else
            #     return false
            false
            # false
            # # current_model = Docs.findOne(slug:Router.current().params.model_slug).model
            # current_model = Router.current().params.model_slug
            # if Template["#{current_model}_doc_edit"]
            #     # console.log 'true'
            #     return true
            # else
            #     # console.log 'false'
            #     return false

        model_template: ->
            # current_model = Docs.findOne(slug:Router.current().params.model_slug).model
            current_model = Router.current().params.model_slug
            "#{current_model}_doc_edit"


    Template.model_doc_edit.events
        'click #delete_doc': ->
            if confirm 'Confirm delete doc'
                Docs.remove @_id
                Router.go "/m/#{@model}"

if Meteor.isClient
    Router.route '/work', (->
        @layout 'layout'
        @render 'shifts'
        ), name:'shifts'

    Template.shifts.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'shift'
    Template.shifts.onRendered ->
    
    Template.shifts.events
        'click .add_shift': ->
            new_id = 
                Docs.insert
                    model:'shift'
            Router.go "/shift/#{new_id}/edit"
            
            
    Template.shifts.helpers
        shift_docs: ->
            # console.log Docs.find(model:'slide').fetch()
            # []
            Docs.find {
                model:'shift'
            }, sort: start_datetime:-1
            
            
if Meteor.isClient
    Router.route '/shift/:doc_id/edit', (->
        @layout 'layout'
        @render 'shift_edit'
        ), name:'shift_edit'



    Template.shift_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'source'

    Template.shift_edit.onRendered ->
            
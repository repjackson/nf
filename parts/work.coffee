if Meteor.isClient
    Router.route '/work', (->
        @layout 'layout'
        @render 'work'
        ), name:'work'

    Template.work.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'shift'
    Template.work.onRendered ->
    
    Template.work.events
        'click .add_shift': ->
            new_id = 
                Docs.insert
                    model:'shift'
    Template.work.helpers
        shift_docs: ->
            # console.log Docs.find(model:'slide').fetch()
            # []
            Docs.find {
                model:'shift'
            }, sort: date:-1
Router.route '/admin', -> @render 'admin'
if Meteor.isClient 
    Template.admin.onCreated ->
        @autorun => @subscribe 'admin_settings', ->
        @autorun => @subscribe 'model_docs', 'foh_call', ->
            
    Template.admin.events
        'click .end_call': ->
            settings = Docs.findOne model:'admin_settings'
            Docs.update settings._id, 
                $set: foh_calling:false
        'click .call_help': ->
            settings = Docs.findOne model:'admin_settings'
            if settings
                Docs.update settings._id, 
                    $set: foh_calling:true
            else 
                Docs.insert 
                    model:'admin_settings'
            Docs.insert 
                model:'foh_call'
            
    Template.admin.helpers
        admin_settings: ->
            Docs.findOne 
                model:'admin_settings'
        call_docs: ->
            Docs.find 
                model:'foh_call'
            
if Meteor.isServer
    Meteor.publish 'admin_settings', ->
        Docs.find 
            model:'admin_settings'
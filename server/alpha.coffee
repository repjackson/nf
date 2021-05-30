Meteor.publish 'alpha_combo', (selected_tags)->
    Docs.find 
        model:'alpha'
        # query: $in: selected_tags
        query: selected_tags.toString()
        
# Meteor.publish 'alpha_single', (selected_tags)->
#     Docs.find 
#         model:'alpha'
#         query: $in: selected_tags
#         # query: selected_tags.toString()
        
        
Meteor.publish 'duck', (selected_tags)->
    Docs.find 
        model:'duck'
        # query: $in: selected_tags
        query: selected_tags.toString()
        
        
Meteor.methods
    call_alpha: (query)->
        @unblock()
        # console.log 'searching alpha for', query
        found_alpha = 
            Docs.findOne 
                model:'alpha'
                query:query
        if found_alpha
            # console.log 'skipping existing alpha for ', query, found_alpha
            target = found_alpha
            # if target.updated
            #     return target
        else
            # console.log 'creating new alpha for ', query
            target_id = 
                Docs.insert
                    model:'alpha'
                    query:query
                    tags:[query]
            target = Docs.findOne target_id       
                   
                    
        HTTP.get "http://api.wolframalpha.com/v1/spoken?i=#{query}&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
            # console.log response.content
            if err then console.log err
            else
                Docs.update target._id,
                    $set:
                        voice:response.content  
            # console.log 'type query', typeof(query)
            # HTTP.get "https://api.wolframalpha.com/v2/query?input=#{query}&mag=1&ignorecase=true&scantimeout=3&format=html,image,plaintext,sound&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
            HTTP.get "https://api.wolframalpha.com/v2/query?input=#{query}&ignorecase=true&scantimeout=3&format=html,image,plaintext&output=JSON&appid=UULLYY-QR2ALYJ9JU",(err,response)=>
                # console.log response
                if err then console.log err
                else
                    parsed = JSON.parse(response.content)
                    Docs.update target._id,
                        $set:
                            response:parsed  
                            updated:true
                                    
                                    
                            
    add_chat: (chat)->
        @unblock()
        # console.log 'chatting alpha for', chat
        now = Date.now()
        found_last_chat = 
            Docs.findOne { 
                model:'chat'
                _timestamp: $lt:now
            }, limit:1
        console.log 'last', found_last_chat
        new_id = 
            Docs.insert 
                model:'chat'
                body:chat
                bot:false
        # console.log 'creating new chat for ', chat
        HTTP.get "http://api.wolframalpha.com/v1/conversation.jsp?appid=UULLYY-QR2ALYJ9JU&i=#{chat}",(err,response)=>
            if err then console.log err
            else
                console.log response
                parsed = JSON.parse(response.content)
                Docs.insert
                    model:'chat'
                    bot:true
                    response:parsed
            
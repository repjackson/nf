# https://api.duckduckgo.com/?q=simpsons+characters&format=json&pretty=1
Meteor.methods
    search_ddg: (query)->
        # @unblock()
        console.log 'searching ddg for', query
        # console.log 'type of query', typeof(query)
        HTTP.get "https://api.duckduckgo.com/?q=#{query}&format=json&pretty=1",(err,response)=>
            # console.log response.content
            if err then console.log err
            else
                parsed = JSON.parse(response.content)
                found = 
                    Docs.findOne 
                        model:'duck'
                        query:query
                if found 
                    found_id = found._id
                    Docs.update found_id,
                        $set:
                            content:parsed
                else
                    found_id = 
                        Docs.insert 
                            model:'duck'
                            query:query
                            content:parsed
                # console.log 'data hading', response.content.Heading
                # console.log 'data url', response.content.AbstractURL
                # for topic in response.content.RelatedTopics
                #     console.log 'related topic', topic
                    
                # console.log 'data length', response.AbstractURL
            #     # console.log 'found data'
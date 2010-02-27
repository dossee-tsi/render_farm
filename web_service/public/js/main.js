$(function(){
    $('.open').click(function(){
        //
    });
    
    $('.accept').click(function(){
        $.post('/tasks/' + getId(this),
            { action: 'accept' },
                function(data){
                if (data.status == 'accepted')
                {
                    getTaskById(data.id).attr('class', 'accepted');
                    getTaskById(data.id).find('td:first + td').text('Accepted');
                }
            },
            'json');
    });
    
    $('.reject').click(function(){
        $.post('/tasks/' + getId(this),
            { action: 'reject' },
            function(data){
                if (data.status == 'rejected')
                {
                    getTaskById(data.id).remove();
                }
            },
            'json');
    });

    function getId(el)
    {
        return $(el).parent().parent().attr('id').substring(4, 44);
    }

    function getTask(el)
    {
        return $(el).parent().parent();
    }

    function getTaskById(id)
    {
        return $('#task' + id);
    }
});

package com.rabbitmq.client.test.server;

import com.rabbitmq.client.GetResponse;
import com.rabbitmq.client.test.BrokerTestCase;
import com.rabbitmq.tools.Host;

import java.io.IOException;
import java.util.List;
import java.util.Map;

public class Firehose extends BrokerTestCase {
    private String q;
    private String firehose;

    @Override
    protected void createResources() throws IOException {
        super.createResources();
        channel.exchangeDeclare("trace", "fanout", false, true, null);
        channel.exchangeDeclare("test", "fanout", false, true, null);
        q = channel.queueDeclare().getQueue();
        firehose = channel.queueDeclare().getQueue();
        channel.queueBind(q, "test", "");
        channel.queueBind(firehose, "trace", "");
    }

    public void testFirehose() throws IOException {
        publishGet("not traced");
        enable();
        GetResponse msg = publishGet("traced");
        disable();
        publishGet("not traced");

        GetResponse publish = basicGet(firehose);
        GetResponse deliver = basicGet(firehose);

        assertNotNull(publish);
        assertNotNull(deliver);
        assertDelivered(firehose, 0);

        // We don't test everything, that would be a bit OTT
        checkHeaders(publish.getProps().getHeaders());

        Map<String,Object> delHeaders = deliver.getProps().getHeaders();
        checkHeaders(delHeaders);
        assertNotNull(delHeaders.get("redelivered"));

        assertEquals(msg.getBody().length, publish.getBody().length);
        assertEquals(msg.getBody().length, deliver.getBody().length);
    }

    private GetResponse publishGet(String key) throws IOException {
        basicPublishVolatile("test", key);
        return basicGet(q);
    }

    private void checkHeaders(Map<String, Object> pubHeaders) {
        assertEquals("test", pubHeaders.get("exchange_name").toString());
        List<Object> routing_keys = (List<Object>) pubHeaders.get("routing_keys");
        assertEquals("traced", routing_keys.get(0).toString());
    }

    private void enable() throws IOException {
        Host.executeCommand("cd ../rabbitmq-server; ./scripts/rabbitmqctl set_env '{trace_exchange, <<\"/\">>}' '<<\"trace\">>'");
    }

    private void disable() throws IOException {
        Host.executeCommand("cd ../rabbitmq-server; ./scripts/rabbitmqctl unset_env '{trace_exchange, <<\"/\">>}'");
    }
}

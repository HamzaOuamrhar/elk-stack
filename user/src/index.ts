import Fastify, { FastifyRequest, FastifyReply } from 'fastify';
import fs from 'fs';
import path from 'path';

const logStream = fs.createWriteStream('./logs/user.log', { flags: 'a' });

const fastify = Fastify({
  logger: {
    level: process.env.LOG_LEVEL || 'info',
    stream: logStream,
    base: null,
    timestamp: () => `,"time":"${new Date().toISOString()}"`
  }
});

function logEvent(level: string, service: string, event: string, data: Record<string, any> = {}) {
  (fastify.log as any)[level]({
    service,
    event,
    ...data,
  });
}


fastify.get('/local', async (req: FastifyRequest, reply: FastifyReply) => {
    logEvent('info', 'user', 'user_login', { 
      resut: 'success',
      provider: "local"
    })
    return { status: 'local login' };
});

fastify.get('/google', async (req: FastifyRequest, reply: FastifyReply) => {
    logEvent('info', 'user', 'user_login', { 
      resut: 'failure',
      provider: "google"
    })
    return { status: 'google login' };
});

fastify.get('/intra', async (req: FastifyRequest, reply: FastifyReply) => {
    logEvent('info', 'user', 'user_login', { 
      resut: 'success',
      provider: "intra"
    })
    return { status: 'intra login' };
});

fastify.get('/accept', async (req: FastifyRequest, reply: FastifyReply) => {
    logEvent('info', 'user', 'friend_request', { 
      action: 'accept',
    });
    return { status: 'accept' };
});

fastify.get('/reject', async (req: FastifyRequest, reply: FastifyReply) => {
    logEvent('info', 'user', 'friend_request', { 
      action: 'reject',
    });
    return { status: 'reject' };
});

fastify.get('/block1', async (req: FastifyRequest, reply: FastifyReply) => {
    logEvent('info', 'user', 'user_block', { 
      blocked_user: "houamrha",
    });
    return { status: 'user blocked' };
});
fastify.get('/block2', async (req: FastifyRequest, reply: FastifyReply) => {
    logEvent('info', 'user', 'user_block', { 
      blocked_user: "aaghla",
    });
    return { status: 'user blocked' };
});

fastify.get('/block3', async (req: FastifyRequest, reply: FastifyReply) => {
    logEvent('info', 'user', 'user_block', { 
      blocked_user: "amentag",
    });
    return { status: 'user blocked' };
});

fastify.get('/block4', async (req: FastifyRequest, reply: FastifyReply) => {
    logEvent('info', 'user', 'user_block', { 
      blocked_user: "rel-isma",
    });
    return { status: 'user blocked' };
});




const start = async () => {
  try {
    await fastify.listen({ port: 3000, host: '0.0.0.0' });
    fastify.log.info('Server running on port 3001');
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};
start();

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


fastify.get('/login', async (req: FastifyRequest, reply: FastifyReply) => {
  logEvent('info', 'user', 'user_login', { userId: '123' });
  return { status: 'login in' };
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

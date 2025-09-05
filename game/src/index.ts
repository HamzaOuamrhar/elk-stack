import Fastify, { FastifyRequest, FastifyReply } from 'fastify';
import fs from 'fs';
import path from 'path';

const logStream = fs.createWriteStream('./logs/game.log', { flags: 'a' });

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

fastify.get('/remote', async (req: FastifyRequest, reply: FastifyReply) => {
  logEvent('info', 'game', 'game_play', {
    mode: "remote"    
  });
  return { status: 'remote' };
});

fastify.get('/local', async (req: FastifyRequest, reply: FastifyReply) => {
  logEvent('info', 'game', 'game_play', {
    mode: "local"    
  });
  return { status: 'local' };
});

fastify.get('/tournament', async (req: FastifyRequest, reply: FastifyReply) => {
  logEvent('info', 'game', 'game_play', {
    mode: "tournament"    
  });
  return { status: 'tournament' };
});

const start = async () => {
  try {
    await fastify.listen({ port: 3000, host: '0.0.0.0' });
    fastify.log.info('Server running on port 3000');
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};
start();

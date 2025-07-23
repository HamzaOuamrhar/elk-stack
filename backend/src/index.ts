import Fastify from 'fastify'
import net from 'net'

const fastify = Fastify()

function sendLogToLogstash(log: object) {
  const client = new net.Socket()

  client.connect(5000, 'logstash', () => {
    client.write(JSON.stringify(log) + '\n')
    client.end()
  })

  client.on('error', (err) => {
    console.error('Logstash connection error:', err.message)
  })
}

fastify.get('/log', async () => {
  const log = {
    message: 'GET /log was called',
    level: 'info',
    timestamp: new Date().toISOString(),
    service: 'backend'
  }

  sendLogToLogstash(log)

  return { status: 'log sent' }
})

fastify.listen({ port: 3000, host: '0.0.0.0' }, (err, address) => {
  if (err) {
    console.error(err)
    process.exit(1)
  }
  console.log(`Server running at ${address}`)
})

#!/usr/bin/env python3

import logging, time, unittest, json

logging.basicConfig(level=logging.DEBUG)

class SimpleTest(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        compiled = SimpleTest.compile_server()
        if not compiled:
            quit("unable to compile backend")

    @classmethod
    def tearDownClass(cls):
        pass

    @classmethod
    def compile_server(cls):
        import subprocess
        logging.info('compiling server')
        args = [
            '/usr/local/bin/mix',
            'compile'
        ]
        try:
            subprocess.run(args, check=True)
        except subprocess.CalledProcessError:
            return False
        return True

    def run_server(port):
        import subprocess
        from os import environ
        logging.info('about to run server')
        modified_env = environ.copy()
        modified_env['PORT'] = str(port)
        args = [
            '/usr/local/bin/mix',
            'run'
        ]
        return subprocess.Popen(args, env=modified_env)

    def _get_random_port(self):
        from random import randint
        return randint(2**10, 2**16)

    def _recvJson(self):
        return json.loads(self._ws.recv())

    def _sendJson(self, data):
        self._ws.send(json.dumps(data))

    def _getConnection(self):
        from websocket import create_connection
        return create_connection('ws://127.0.0.1:{}'.format(self._port))

    def setUp(self):
        self._port = self._get_random_port()
        self._server_proc = SimpleTest.run_server(self._port)
        
        logging.info('about to connect to server')

        for i in range(1, 4):
            print('({}s)'.format(4-i))
            time.sleep(1)

        # create a default connection
        self._ws = self._getConnection()

        time.sleep(1)

    def tearDown(self):
        time.sleep(0.1)

        self._ws.close()

        self._server_proc.kill()

    def testCreateBlock(self):
        self._sendJson({"status": "ok"})
        resp = self._recvJson()
        logging.info('received: {}'.format(resp))

def main():
    unittest.main()

if '__main__' == __name__:
    main()
    

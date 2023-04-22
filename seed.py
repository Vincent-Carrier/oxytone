import asyncio

from aredis_om import get_redis_connection

from app import init
from app.lib.langs.ag.lexicon import seed_lsj


async def main():
    await init()
    redis = await get_redis_connection()
    redis.flushall()
    await seed_lsj()

asyncio.run(main())

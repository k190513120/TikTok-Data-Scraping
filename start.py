# ==============================================================================
# Copyright (C) 2021 Evil0ctal
#
# This file is part of the Douyin_TikTok_Download_API project.
#
# This project is licensed under the Apache License 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
# 　　　　 　　  ＿＿
# 　　　 　　 ／＞　　フ
# 　　　 　　| 　_　 _ l
# 　 　　 　／` ミ＿xノ
# 　　 　 /　　　 　 |       Feed me Stars ⭐ ️
# 　　　 /　 ヽ　　 ﾉ
# 　 　 │　　|　|　|
# 　／￣|　　 |　|　|
# 　| (￣ヽ＿_ヽ_)__)
# 　＼二つ
# ==============================================================================
#
# Contributor Link, Thanks for your contribution:
# - https://github.com/Evil0ctal
# - https://github.com/Johnserf-Seed
# - https://github.com/Evil0ctal/Douyin_TikTok_Download_API/graphs/contributors
#
# ==============================================================================


from app.main import Host_IP, Host_Port
import uvicorn
import os

if __name__ == "__main__":
    # 强制使用配置文件中的端口，忽略环境变量 PORT
    # 这是为了解决 Koyeb 平台强制设置 PORT=80 导致权限拒绝的问题
    port = Host_Port
    
    print(f"Environment PORT: {os.environ.get('PORT', 'Not set')}")
    print(f"Config Host_Port: {Host_Port}")
    print(f"Force using config port: {port} (ignoring environment PORT)")
    print(f"Starting server on {Host_IP}:{port}")
    
    try:
        uvicorn.run(
            "app.main:app",
            host=Host_IP,
            port=port,
            reload=False,
            access_log=True,
            log_level="info"
        )
    except Exception as e:
        print(f"Failed to start server: {e}")
        sys.exit(1)

import { http } from '@kit.NetworkKit'
import { ChatResponse } from '../models/chat'

export async function requestMessage(content: string) {
  const req = http.createHttp()
  try {
    const res = await req.request(`https://api.ownthink.com/bot?appid=xiaosi&userid=user&spoken=${encodeURIComponent(content)}`)
    return JSON.parse(res.result as string) as ChatResponse
  } catch (error) {
    return Promise.reject(error)
  } finally {
    req.destroy()
  }
}
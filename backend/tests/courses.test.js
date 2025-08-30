const request = require('supertest');
const app = require('../index');

describe('Courses API', () => {
  test('lists available courses', async () => {
    const res = await request(app).get('/courses');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body).toHaveLength(1);
    expect(res.body[0].name).toMatch(/Shetland/i);
  });

  test('fetches a course by id', async () => {
    const res = await request(app).get('/courses/shetland');
    expect(res.status).toBe(200);
    expect(res.body.id).toBe('shetland');
  });

  test('returns 404 for unknown course', async () => {
    const res = await request(app).get('/courses/unknown');
    expect(res.status).toBe(404);
  });
});
